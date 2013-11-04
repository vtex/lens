module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')
	replacements =
		'\<\!\-\- VERSION \-\-\>' : pkg.version

	grunt.initConfig
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

		sass:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**/*.scss', '**/*.sass']
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
			'dist/lens.zip': ['manifest.json', 'build/**/*', 'icons/**/*', '_locales/**/*']

		concurrent:
			transform: ['copy:main', 'coffee', 'sass']

	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'make', ['clean', 'concurrent:transform', 'string-replace']
	grunt.registerTask 'default', ['make', 'watch:main']
	grunt.registerTask 'dist', ['make', 'zip']