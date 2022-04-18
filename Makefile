REQUIREMENTS_DIR := requirements
SRC_DIR := netflix
PIP_COMPILE_ARGS := --generate-hashes --no-header --no-emit-index-url --verbose
PIP_COMPILE := cd $(REQUIREMENTS_DIR) && pip-compile $(PIP_COMPILE_ARGS)
DJANGO_ADMIN := django-cadmin

.PHONY: fix
fix:
	isort .

.PHONY: lint
lint:
	flake8
	isort -qc .

.PHONY: po
po:
	cd $(SRC_DIR) && $(DJANGO_ADMIN) makemessages --no-wrap --locale=en --locale=ru

.PHONY: mo
mo:
	cd $(SRC_DIR) && $(DJANGO_ADMIN) compilemessages --locale=en --locale=ru

.PHONY: compile-requirements
compile-requirements:
	pip install -U pip-tools
	$(PIP_COMPILE) requirements.in
	$(PIP_COMPILE) requirements.lint.in
	$(PIP_COMPILE) requirements.dev.in
	test -f $(REQUIREMENTS_DIR)/requirements.local.in && $(PIP_COMPILE) requirements.local.in || exit 0

.PHONY: sync-requirements
sync-requirements:
	pip install -U pip-tools
	cd $(REQUIREMENTS_DIR) && pip-sync requirements.txt requirements.*.txt

.DEFAULT_GOAL :=
