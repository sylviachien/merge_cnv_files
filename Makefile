IMAGE_NAME=merge-cnv-files
VERSION=latest
#REFERENCE_PROJECT=pipeline-development-chienm2-reference
REFERENCE_PROJECT=cnv-reference
TOOL_NAME=merge-cnv-files

sbg_build:
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(VERSION) -t bms-images.sbgenomics.com/bristol-myers-squibb/$(IMAGE_NAME):$(VERSION) .
sbg_push:
	docker push bms-images.sbgenomics.com/bristol-myers-squibb/$(IMAGE_NAME):$(VERSION)
sbg_pack: 
	sbpack default bristol-myers-squibb/$(REFERENCE_PROJECT)/$(TOOL_NAME) merge-cnv-files.cwl

#sbpack default bristol-myers-squibb/$(REFERENCE_PROJECT)/$(TOOL_NAME) merge_cnv_files.cwl
