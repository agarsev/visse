.ONESHELL:

all:
	echo "make setup"

setup:
	cd quevedo && poetry build
	poetry install --no-root --remove-untracked

web:
	@http-server frontend &
	cd backend ; poetry run uvicorn main:app --reload &
	wait
