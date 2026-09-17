# bcd-bausteine-python-en

Combined book of all English-language Python building blocks ("Bausteine der Datenanalyse"), assembled via git submodules — the English counterpart to [bcd-bausteine-python](https://github.com/bausteine-der-datenanalyse/bcd-bausteine-python).

[https://bausteine-der-datenanalyse.github.io/bcd-bausteine-python-en/output/book/](https://bausteine-der-datenanalyse.github.io/bcd-bausteine-python-en/output/book/)

CI automatically re-renders and deploys the combined book on every push (see `.github/workflows/build_n_deploy.yml`). Only HTML is built — PDF output is disabled for this combined book because cross-submodule relative image paths break LaTeX/PDF assembly; the individual building-block repos still each produce their own PDF.

After updating submodules, run `scripts/generate_quarto_yaml.sh` to regenerate `_quarto.yml` and `scripts/gen_requirements_txt.sh` to regenerate `requirements.txt`.
