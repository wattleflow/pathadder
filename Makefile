PYTHON := $$(which python)
PIP := $$(PYTHON) -m pip
SIGN=":"
SEQUENCE := $$(printf "%0.s${SIGN}" $$(seq 1 200))

define headerline
	printf "%*.*s\n" $1 $2 "$(SEQUENCE)"
endef

define header
	printf "%*.*s\n" $1 $2 "::: $3:$4 $(SEQUENCE)"
endef

define format_txt
	printf "%*.*s\n" $1 $2 "::: $3: $4 $$(printf "%0.s#" $$(seq 1 200))"
endef

conda-build:
	@python -m build
	@#python setup.py sdist bdist_wheel

conda-info:
	@PACKAGE_NAME="patthadder" && \
	if pip list 2>/dev/null | grep -q patthadder; then \
		pip show $$PACKAGE_NAME 2>/dev/null ;\
		pip show $$PACKAGE_NAME 2>/dev/null | grep -q "Location: .*site-packages" && echo "Library '$$PACKAGE_NAME' IS COMPILED!." || echo "Library '$$PACKAGE_NAME' IS INSTALLED IN EDITABLE MODE." ;\
	fi

conda-install-java:
	@if ! java --version 2>/dev/null; then \
		bash -c "conda activate pathadder && conda install openjdk -c conda-forge" ;\
	fi

conda-setup-env:
	@found=$$(conda info -e | awk '$$1 ~ "pypi-test" { print $$1 }' | wc -l) && \
	if [ $$found -gt 0 ]; then \
		echo "Environment already exist ..." ;\
	else \
		echo "Will create environement in a moment ..." ;\
		conda create --name pypi-test python=3.8 && sleep 2 ;\
	fi
	@conda deactivate && conda activate pypi-test;\

conda-setup-req: conda-setup-env
	@echo "You should run this proces only once, if you don't have pathadder dev environement configured."
	@read -p "Do you want to continue (N/y)" ans && if [ "$$ans" = "y" ]; then \
		pip install setuptools build wheel twine tox flake8 ;\	
	fi

docker:
	@echo "Building docker image ..."
	@echo "cd dockers/<dir> && make build 

git-create-key:
	@echo "Genereting key"
	@ssh-keygen -t ed25519 -C "wattleflow@outlook.com"

git-config:
	@git config user.name "wattleflow"
	@git config user.email "wattleflow@outlook.com"
	@git remote add origin https://github.com/wattleflow/pathadder.git 2>/dev/null
	@git remote -v

git-commit: git-ssh-server
	@datum=$$(date +%Y%m%d%H)
	@git commit -m "Commit $$datum."
	@git branch -M default
	@git push -u origin default
	@echo "git remote set-url origin git@github.com:wattleflow/pathadder.git" >/dev/null

git-init: 
	@git init
	@git add .
	@git remote -v

git-ssh-server:
	@echo "SSH: Starting agent and adding key to server ..."
	@pgrep -x ssh-agent | while read pid; do if [ $$pid -gt 0 ]; then kill -9 $$pid 2>/dev/null; sleep 2; fi; done
	eval "$$(ssh-agent -s)" && sleep 4 && ssh-add $$HOME/.ssh/id_rsa	
	@ssh -T git@github.com

install-download-conda:
	@touch /tmp/miniconda.sh
	@if [ ! -f "/tmp/miniconda.sh" ]; then \
		echo "Downloading miniconda ..." ;\
		curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh ;\
	fi

install-conda: download-conda
	@touch /tmp/miniconda.sh
	@sha256sum /tmp/miniconda.sh | cut -d " " -f1 | while read cal; do \
		hash="636b209b00b6673471f846581829d4b96b9c3378679925a59a584257c3fef5a3" ;\
		hash="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ;\
		if [ "$$cal" = "$$hash" ]; then \
			echo "Miniconda: OK \n  $$hash\n  $$cal" ;\
			echo "Installation will start in sec ..." && bash /tmp/miniconda.sh 2> /dev/null ;\
			echo "Cleaning up ..." ;\
			rm -rf "/tmp/miniconda.sh" ;\
		else \
			echo "ERROR: hash differs\n   $$cal\n   $$hash" ;\
		fi \
	done

jupyter:
	@echo "Starting jupyter-lab .."
	@pgrep jupyter-lab | while read pid; do if [ $$pid -gt 0 ]; then kill -9 $$pid 2>/dev/null; sleep 3; fi; done
	@conda run -n pathadder jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --LabApp.token='' &
	@sleep 5 && echo $$(pgrep jupyter-lab)
	@find $$(jupyter --runtime-dir)/* -type f -name "*secret*" | while read n; do cat $$n; done

flake-project:
	@echo "Project analysis ..."
	@flake8 . #--select=F400

project-backup: clean
	@tarfile=".backup/$$(date +%Y%m%d%H)-pathadder.tar.gz" && \
	tar -czf "$$tarfile" $$(pwd) 2> /dev/null && \
	echo "Backup completed: $$tarfile"


build:
	@python -m setuptools_scm
	@python -m build 
	@### python -m build --no-isolation --skip-dependency-check

project-cache:
	@echo "__pycache__ .ipynb_checkpoints" | tr " " "\n" | while read dir; do \
		find . -type d -name "$$dir" -exec rm -rfv {} +; \
	done
	@echo "Cache cleaned!"

clean: project-cache
	@echo "tests/ build *.egg-info dist __pycache__" | tr " " "\n" | while read dir; do \
		find . -name "$$dir" -type d -exec rm -rfv {} + 2>/dev/null;\
	done

compile: clean
	@if ! pip list 2>/dev/null | grep -q pathadder; then \
		echo "Compiling pathadder ..." ;\
		pip install -v --compile . ;\
	fi

project-editable: project-clean
	@echo "Installing editable project ..."
	@if ! pip list 2>/dev/null | grep -q pathadder; then \
		echo "Installing pathadder!"; \
		pip install -e . ; \
		pip show pathadder; \
	else \
		echo "pathadder is already installed!"; \
	fi

install: clean project-build
	@subdir=$$(basename $$(pwd)) && \
	if [ "$$subdir" = "core" ]; then \
		pip uninstall pathadder -y -v 2>/dev/null ;\
	fi
	@package=$$(find dist/* -name "*.whl") && pip install $$package
	@pip uninstall $$name -y -v 2>/dev/null

project-pylint: clean
	@echo "Generating pylint for pathadder ..."
	@if ! pip list 2>/dev/null | grep -q pylint; then \
		echo "pylint nije instaliran. Pokrenite: pip install pylint"; \
		pip install pylint ;\
	fi
	@pylint pathadder | tee /tmp/pylint.txt
	@echo "See details in (/tmp/pylint.txt)."

project-reinstall-old: clean
	@echo "Reinstalling pathadder ..."
	@echo "pip install --user --upgrade --force-reinstall --ignore-installed --no-binary" 2>/dev/null
	@pip install -v --upgrade --ignore-installed --force-reinstall .

project-configure:
	@if ! pip list 2>/dev/null | grep -E "build|setuptools|setuptools_scm|twine|wheel|rutina"; then \
		echo "You may need to install first: build setuptools wheel" ;\
	fi
	@pip install --upgrade pip build setuptools setuptools_scm wheel twine

project-upgrade:
	@echo "Upgrading env pip and packages ..."
	@if ! pip list 2>/dev/null | grep -q pathadder; then \
		python -m pip install --upgrade pip
		echo "Upgrading pathadder package ..." ;\
		pip install -v --upgrade . ;\
	done


project-vscode:
	@mkdir -p .vscode-test 2> /dev/null
	@echo "{" >  .vscode-test/settings.json
	@echo -n '   "python.envFile": "' >> .vscode-test/settings.json
	@echo -n "$$(pwd)/.env" >> .vscode-test/settings.json
	@echo '",' >> .vscode-test/settings.json
	@echo -n '   "python.analysis.extraPaths": [ "$${workspaceFolder}"' >> .vscode-test/settings.json
	@conda info -e | grep $$(basename $$(pwd)) | awk '{print $$3}' | while read path; do \
		echo -n ', "'; echo -n $$path; echo -n '"'; \
		echo -n ', "'; echo -n $$path/bin/python; echo -n '"'; \
		echo '" ]'; \
	done >> .vscode-test/settings.json
	@echo "}" >> .vscode-test/settings.json
	@ls -la .vscode-test/
	@cat .vscode-test/settings.json

sys-process:
	@echo "Syestem processes: Please wait ... [this is slow process]"
	@sudo netstat -tp | awk 'NR > 2 {split($$4, a, ":"); split($$7, b, "/"); if (length(b[1]) > 3) print a[2], b[1];}' | while read line; do \
		pid=$$(echo $$line | cut -d" " -f2)                  ;\
		port=$$(echo $$line | cut -d" " -f1)                 ;\
		$(call header,1,180,Port,$$port)                     ;\
		echo "::: [ lsof -i :$${port} ] :::\n"               ;\
		sudo lsof -i :$$port && echo                         ;\
		echo "::: [ ps -p $$pid -o pid,user,command ] :::\n" ;\
		ps -p $$pid -o pid,user,command                      ;\
		echo                                                 ;\
	done
	@# sudo fuser -v -a $$port/tcp && echo ;

sys-threads:
	@echo "Syestem threads: Please wait ... [this is slow process]"
	@sudo netstat -tp | awk 'NR > 2 {split($$4, a, ":"); split($$7, b, "/"); if (length(b[1]) > 3) print a[2], b[1];}' | while read line; do \
	{ \
		pid=$$(echo $$line | cut -d" " -f2)                     ;\
		port=$$(echo $$line | cut -d" " -f1)                    ;\
		$(call header,1,180,Pid ,$$pid)                         ;\
		$(call header,1,180,Port,$$port)                        ;\
		echo "::: [ fuser -avu $${port}/tcp ] :::\n"            ;\
		sudo fuser -avu $$port/tcp && echo                      ;\
		echo "::: [ lsof -i :$${port} ] :::\n"                  ;\
		sudo lsof -i :$$port                                    ;\
		echo "::: [ ps -p $${pid} -o pid,user,command ] :::\n"  ;\
		ps -p $$pid -o pid,user,command                         ;\
		echo "\n\n"                                             ;\
	} \
	done

sftp-ssh-clean:
	@echo "SSH: Cleanining up ..."
	@pgrep -x ssh-agent | while read pid; do if [ $$pid -gt 0 ]; then kill -9 $$pid 2>/dev/null; sleep 2; fi; done
	@ssh-keygen -f '$$HOME/.ssh/known_hosts' -R '0.0.0.0:2222' 2>/dev/null
	@rm -rf $$HOME/.ssh/id_rsa $$HOME/.ssh/id_rsa.pub 2>/dev/null

sftp-ssh-copy:
	@echo "Copying key to server $$USER@127.0.0.1"
	@ssh-copy-id -p 2222 -t $$HOME/.ssh/id_rsa.pub $$USER@127.0.0.1
	@echo "cp $$HOME/.ssh/id_rsa.pub $$HOME/projects/pathadder/dockers/<name>""

sftp-ssh-make:
	@echo "Setting up ssh ... $$USER@127.0.0.1"
	@secret=$(cat secret.yaml | yq .secret) && \
	 ssh-keygen -t rsa -C "$$USER" -b 4096 -m PEM -f $$HOME/.ssh/id_rsa -N "$$secret" && chmod 600 $$HOME/.ssh/id_rsa

ssh-start:
	@echo "SSH: Starting agent and adding key to server ..."
	@pgrep -x ssh-agent | while read pid; do if [ $$pid -gt 0 ]; then kill -9 $$pid 2>/dev/null; sleep 2; fi; done
	@eval "$$(ssh-agent -s)" && sleep 4 && ssh-add $$HOME/.ssh/id_rsa

twine:
	@package=$$(find dist/* -name "*.whl") && twine upload $$package

help:
	@awk '/^(\w+)([:-])/' "$(MAKEFILE_LIST)" | cut -d ":" -f1
