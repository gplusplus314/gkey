.PHONY: vibraphone
.PHONY: xylophone

vibraphone:
	./bin/build.sh vibraphone
	./bin/flash.sh vibraphone

xylophone:
	./bin/build.sh xylophone
	./bin/flash.sh xylophone

