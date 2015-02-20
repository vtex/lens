module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')
	manifest = grunt.file.readJSON('manifest.json')

	replacements =
		'\<\!\-\- VERSION \-\-\>' : manifest.version

	configObj =
		manifestVersion: manifest.version
		relativePath: ''

		clean:
			main: ['build', 'dist']

		copy:
			main:
				expand: true
				cwd: 'src/'
				src: ['**', '!**/*.coffee', '!**/*.less', '!**/*.scss', '!**/*.sass']
				dest: 'build/<%= relativePath %>'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**/*.coffee']
					dest: 'build/<%= relativePath %>/'
					ext: '.js'
				]

		less:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**/*.less']
					dest: 'build/<%= relativePath %>/'
					ext: '.css'
				]

		'string-replace':
			version:
				options:
					replacements: ({'pattern': new RegExp(key, "g"), 'replacement': value} for key, value of replacements)
				files:
					'build/popup.html': 'build/popup.html'

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*', 'icons/**/*', '_locales/**/*']
				tasks: ['make']

		zip:
			'long-format':
				src: ['manifest.json', 'build/**/*', 'icons/**/*', '_locales/**/*']
				dest: "dist/lens-<%= manifestVersion %>.zip"

		concurrent:
			transform: ['copy:main', 'coffee', 'less']

	grunt.initConfig(configObj)
	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'make', ['clean', 'concurrent:transform', 'string-replace']
	grunt.registerTask 'default', ['make', 'watch:main']
	grunt.registerTask 'dist', ['make', 'zip']