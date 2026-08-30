{pkgs, ...}:
{
	environment.systemPackages = with pkgs;[

	vscode
	jupyter
    	antigravity-ide

	gcc
	gnumake

	python3
	python3Packages.pip
	python3Packages.ipykernel
	python3Packages.jupyterlab
	python3Packages.pyzmq

	docker
	docker-compose

	minikube
	kubectl

	nodejs
	];
}
