module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')
	grunt.initConfig
		relativePath: ''

		clean:
			main: ['dist']

		copy:
			main:
				expand: true
				cwd: 'src/'
				src: ['**', '!**/*.coffee', '!**/*.less', '!**/*.scss', '!**/*.sass']
				dest: 'dist/<%= relativePath %>'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**/*.coffee']
					dest: 'dist/<%= relativePath %>/'
					ext: '.js'
				]

		sass:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**/*.scss', '**/*.sass']
					dest: 'dist/<%= relativePath %>/'
					ext: '.css'
				]

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.coffee', 'src/**/*.js', 'src/**/*.less', 'src/**/*.css']
				tasks: ['make']

		concurrent:
			transform: ['copy:main', 'coffee', 'sass']

	grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'make', ['clean', 'concurrent:transform']
	grunt.registerTask 'default', ['make', 'watch:main']