create-venv:
	test -d venv || python3 -m venv venv

install-requirements:
	pip install -r requirements.txt

update-requirements:
	pip install -r requirements.txt --upgrade

spriteset:
	zxp2boriel --input assets/spriteset.zxp --width 16 --rows 1 --cols 1 --output src/spriteset.bas --name sprite --no-attributes

build:
	zxbc -W150 -W160 -W170 -W190 -W130 -O 2 -D HIDE_LOAD_MSG src/main.bas -aB --output-format=tap -o dist/flapper-boriel.tap