IMAGE_NAME=merge-cnv-files
VERSION=0.0.1
#REFERENCE_PROJECT=pipeline-development-chienm2-reference
REFERENCE_PROJECT=cnv-reference
TOOL_NAME=merge-cnv-files
ARV_MERGE_CNV_FILES_PIPELINE=xngs1-7fd4e-n7tz4h8t5y9vge1
ARV_REFERENCE_PROJECT=xngs1-j7d0g-1n6fxsmyxofhcdp

sbg_build:
	docker build --platform linux/amd64 -t $(IMAGE_NAME):$(VERSION) -t bms-images.sbgenomics.com/bristol-myers-squibb/$(IMAGE_NAME):$(VERSION) .
sbg_push:
	docker push bms-images.sbgenomics.com/bristol-myers-squibb/$(IMAGE_NAME):$(VERSION)
sbg_pack: 
	sbpack default bristol-myers-squibb/$(REFERENCE_PROJECT)/$(TOOL_NAME) merge-cnv-files.cwl

#sbpack default bristol-myers-squibb/$(REFERENCE_PROJECT)/$(TOOL_NAME) merge_cnv_files.cwl

arvados-push-workflows:
	arvados-cwl-runner --update-workflow ${ARV_MERGE_CNV_FILES_PIPELINE} --project-uuid ${ARV_REFERENCE_PROJECT} merge-cnv-files.cwl