.PHONY: cat show

cat:
	chezmoi cat ~/a.tmpl

show:
	cat .chezmoiignore | chezmoi execute-template
	cat .chezmoiexternal.toml.tmpl | chezmoi execute-template
