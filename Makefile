SHELL=bash
define packcmd
jq -crn $(foreach js,$(wildcard triggers/*.js),--rawfile $(patsubst triggers/%.js,trigger.%,$(js)) $(js)) \
	$(foreach json,$(wildcard triggers/*.json),--slurpfile $(patsubst triggers/%.json,triggerinfo.%,$(json)) $(json)) \
	$(foreach json,$(wildcard packs/*.json),--slurpfile $(patsubst packs/%.json,pack.%,$(json)) $(json)) \
	-f pack.jq
endef
# --slurpfile package package.json \

.tmp:
	mkdir .tmp

.tmp/pack.json: $(wildcard triggers/*.js) $(wildcard triggers/*.json) $(wildcard packs/*.json) pack.jq .tmp
	$(packcmd) >$@.tmp
	mv -f $@.tmp $@

show-pack: .tmp/pack.json
	jq '.triggers|=map(if (.configuration?.code?|length)>100 then .configuration.code|=length else . end|if (.configuration?.workspace?|length)>0 then .configuration.workspace|=length else . end)|.tables|=map(.name)|.views|=map(.name)' $<

publish: packname.txt .tmp/pack.json
	curl -sSXPOST -H "Authorization: Bearer $$store_token" -H 'Content-Type: application/json' \
		"$${store_url:-http://store.saltcorn.com/}api/action/update_pack" \
		--data @<(jq -c --rawfile packname packname.txt '{name:($$packname|rtrimstr("\n")),pack:.}' .tmp/pack.json)

clean:
	rm -rf .tmp
	mkdir -p .tmp
