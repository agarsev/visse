all:
	echo "make setup"

setup:
	cd quevedo && poetry build
	poetry install --no-root --remove-untracked

run_backend:
	poetry run uvicorn backend.main:app --reload
