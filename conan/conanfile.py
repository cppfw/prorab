import os
from conan import ConanFile
from conan.tools.scm import Git
from conan.tools.files import load, update_conandata, copy
from conan.tools.layout import basic_layout

class ProrabConan(ConanFile):
	name = "prorab"
	license = "MIT"
	author = "Ivan Gagis <igagis@gmail.com>"
	url = "http://github.com/cppfw/" + name
	description = "prorab build script"
	settings = "os", "compiler", "build_type", "arch"
	package_type = "build-scripts"

	def requirements(self):
		self.requires("make/[>=4.4.1]", run=True, visible=True)

	# save commit and remote URL to conandata.yml for packaging
	def export(self):
		git = Git(self)
		scm_url = git.get_remote_url()
		# NOTE: Git.get_commit() doesn't work properly,
		# it gets latest commit of the folder in which conanfile.py resides.
		# So, we use "git rev-parse HEAD" instead as it gets the actual HEAD
		# commit regardless of the current working directory within the repo.
		scm_commit = git.run("rev-parse HEAD") # get current commit
		update_conandata(self, {"sources": {"commit": scm_commit, "url": scm_url}})

	def source(self):
		git = Git(self)
		sources = self.conan_data["sources"]
		# shallow fetch commit
		git.fetch_commit(url=sources["url"], commit=sources['commit'])
		# shallow clone submodules
		git.run("submodule update --init --remote --depth 1")

	def package(self):
		src_dir = os.path.join(self.build_folder, "src")
		dst_include_dir = os.path.join(self.package_folder, "include")

		copy(conanfile=self, pattern="*.mk", dst=dst_include_dir, src=src_dir, keep_path=True)

	def package_info(self):
		self.buildenv_info.append("MAKE_INCLUDE_DIRS_ARG", "--include-dir=" + os.path.join(self.package_folder, "include"))

	def package_id(self):
		# change package id only when minor or major version changes, i.e. when ABI breaks
		self.info.requires.minor_mode()

		# makefiles do not depend on any of os, arch, compiler, build_type
		del self.info.settings.os
		del self.info.settings.arch
		del self.info.settings.compiler
		del self.info.settings.build_type
