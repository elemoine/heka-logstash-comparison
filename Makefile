HEKA_DEB = heka_0.10.0_amd64.deb
NUM_LOG_FILES = 100

PWD = $(shell pwd)

.PHONY: generate-logs
generate-logs: logs/kern1.log

.PHONY: get-heka
get-heka: .build/$(HEKA_DEB)

.PHONY: build-heka
build-heka:
	docker build -t elemoine/lma_collector

.PHONY: run-heka
heka: output
	docker run -it --rm --name="heka" -v $(PWD)/heka.conf:/config-dir/heka.conf -v $(PWD)/logs:/logs -v $(PWD)/output:/output elemoine/lma-collector -config=/config-dir/heka.conf

.PHONY: elasticsearch
elasticsearch:
	 docker run --rm -it --name="elasticsearch" elasticsearch

.PHONY: logstash
logstash: output
	docker run -it --rm -u="root" --name="logstash" -v $(PWD)/logstash.conf:/config-dir/logstash.conf -v $(PWD)/logs:/logs -v $(PWD)/output:/output logstash logstash -f /config-dir/logstash.conf

.PHONY: heka-stats
heka-stats:
	docker stats heka

.PHONY: logstash-stats
logstash-stats:
	docker stats logstash

.PHONY: output
output:
	mkdir -p output
	chmod a+w output

.PHONY: watch-output
watch-output:
	/usr/bin/time watch wc -l output/logs

.build/$(HEKA_DEB):
	mkdir -p $(dir $@)
	wget -O $@ https://github.com/mozilla-services/heka/releases/download/v0.10.0/heka_0.10.0_amd64.deb

logs/kern1.log:
	mkdir -p $(dir $@)
	for i in $$(seq 1 $(NUM_LOG_FILES)); do cp kern.log logs/kern$${i}.log; done
	chmod -R a+r $(dir $@)

.PHONY: clean
clean:
	sudo rm -rf output

.PHONY: cleanall
cleanall: clean
	rm -rf logs
