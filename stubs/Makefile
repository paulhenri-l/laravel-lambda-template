SHELL := /bin/bash

all: package_code package_assets

clean:
	rm -rf .build

build_env: clean
	mkdir -p .build/code && \
	mkdir -p .build/assets && \
	cd .build/code && \
	rsync -avr \
			   --exclude="/.build" \
			   --exclude="/.env" \
			   --exclude="/node_modules" \
			   --exclude="/storage" \
			   --exclude="/terraform" \
			   --exclude="/tests" \
			   --exclude="/vendor" \
			   --exclude='/.git' \
			   --exclude='/.idea' \
			   ../../ .

build: build_env
	cd .build/code && \
	composer validate && \
	COMPOSER_MIRROR_PATH_REPOS=1 composer install --no-dev && \
	php artisan event:cache && \
	npm ci && npm run prod && rm -rf node_modules

package_assets: build
	cd .build/assets && \
	cp -r ../code/public/ . && \
	rm index.php .htaccess web.config mix-manifest.json && \
	zip -r ../assets.zip ../assets

package_code: build
	cd .build/code && \
	zip -r ../code.zip . -x@exclude.lst

deploy: package_code package_assets
	cd terraform && \
	terraform workspace select production || terraform workspace new production && \
	terraform apply -auto-approve && \
	rm -rf .build

destroy:
	cd terraform && \
	terraform workspace select production || terraform workspace new production && \
	terraform destroy -auto-approve
