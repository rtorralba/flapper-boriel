create-venv:
	test -d venv || python3 -m venv venv

activate-venv:
	source venv/bin/activate

install-requirements:
	pip install -r requirements.txt

update-requirements:
	pip install -r requirements.txt --upgrade

spriteset:
	zxp2boriel --input assets/spriteset.zxp --width 16 --rows 1 --cols 1 --output src/generated/spriteset.bas --name sprite --no-attributes

tileset:
	zxp2boriel --input assets/tileset.zxp --width 8 --rows 1 --cols 15 --output src/generated/tileset.bas --name tile

assets:
	$(spriteset)
	$(tileset)

build:
	zxbc -W150 -W160 -W170 -W190 -W130 -O 2 -S 24576 -H 128 --heap-address 23755 -D HIDE_LOAD_MSG src/main.bas -taB -o dist/flapper.tap

run:
	fuse dist/flapper.tap