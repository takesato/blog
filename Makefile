run:
	hugo serve -D \
	--disableFastRender \
	-b https://${CODESPACE_NAME}-1313.preview.app.github.dev/blog \
	--debug \
	--appendPort=false

info:
	gh api \
		-H "Accept: application/vnd.github+json" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		/repos/${GITHUB_REPOSITORY}/pages | jq .