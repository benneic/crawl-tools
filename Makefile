BUCKET := btm-crawl-data
DATE   := $(shell date "+%y_%m_%dT%H_%M")
OUT    := dump-$(DATE).txt

# echo output in cyan
define cecho
	@tput setaf 6
	@echo $1
	@tput sgr0
endef

all:
	@echo The date is $(DATE)

analyse:
	GOOGLE_APPLICATION_CREDENTIALS=~/creds-crawler.json .venv/bin/jupyter notebook jupyter-ausbt.ipynb

setup:
	go get -u github.com/benjaminestes/crawl/...
	crawl schema > schema.json
	virtualenv .venv
	.venv/bin/pip3.7 install --upgrade jupyter google-cloud-bigquery[pandas] matplotlib

urls.txt:
	crawl sitemap https://www.ausbt.com.au/sitemaps/index.xml > urls.txt

crawl-ausbt: urls.txt
	#sed -i '' -e"s/test.executivetraveller.com/dev.executivetraveller.com/" urls.txt
	#sed -i '' -e"s/https:/http:/" urls.txt
	crawl list config.json < urls.txt | gsutil cp - gs://$(BUCKET)/ausbt/$(OUT)
	bq load --source_format=NEWLINE_DELIMITED_JSON crawl.ausbt_$(DATE) gs://$(BUCKET)/ausbt/$(OUT) schema.json
