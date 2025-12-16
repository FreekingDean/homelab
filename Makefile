.PRECIOUS: kubernetes/apps/%/kustomization.yaml kubernetes/apps/%/namespace.yaml

kubernetes/apps/%/kustomization.yaml: template/namespace/kustomization.yaml 
	sed "s/__NAMESPACE__/$*/g" $< > $@

kubernetes/apps/%/namespace.yaml: template/namespace/namespace.yaml
	sed "s/__NAMESPACE__/$*/g" $< > $@

.PHONY: clean.%
clean.%:
	rmdir kubernetes/apps/$*

.PHONY: namespace.%
namespace.%: kubernetes/apps/%/namespace.yaml kubernetes/apps/%/kustomization.yaml
	@echo "Namespace $* generated."
