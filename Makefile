.PHONY: vibraphone
.PHONY: vibraphone-right
.PHONY: flash-vibraphone
.PHONY: flash-vibraphone-right
.PHONY: xylophone
.PHONY: reset-vibraphone

vibraphone:
	./bin/build.sh vibraphone && ./bin/flash.sh vibraphone

vibraphone-right:
	./bin/build.sh vibraphone && ./bin/flash.sh vibraphone.right

flash-vibraphone:
	./bin/flash.sh vibraphone

flash-vibraphone-right:
	./bin/flash.sh vibraphone.right

xylophone:
	./bin/build.sh xylophone && ./bin/flash.sh xylophone

reset-vibraphone:
	./bin/reset.sh vibraphone
