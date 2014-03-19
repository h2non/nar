'use strict'

module.exports = (grunt) ->

  (require 'matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean: ['lib', 'test/*.js', 'test/fixtures/.tmp/**']

    livescript:
      options:
        bare: true
        prelude: true
      src:
        expand: true
        cwd: 'src/'
        src: ['**/*.ls']
        dest: 'lib/'
        ext: '.js'
      test:
        expand: true
        cwd: 'test/lib'
        src: ['**/*.ls']
        dest: 'test/lib'
        ext: '.js'

    mochacli:
      options:
        require: ['chai']
        compilers: ['ls:LiveScript']
        timeout: 5000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
      all:
        src: [
          'test/*.ls'
        ]

    watch:
      options:
        spawn: false
      src:
        files: ['src/**/*.ls']
        tasks: ['test']
      test:
        files: ['test/**/*.ls']
        tasks: ['test']


  grunt.registerTask 'compile', [
    'clean'
    'livescript'
  ]

  grunt.registerTask 'test', [
    'compile',
    'mochacli'
  ]

  grunt.registerTask 'dev', [
    'compile',
    'mochacli'
    'watch'
  ]

  grunt.registerTask 'publish', [
    'test'
    'release'
  ]

  grunt.registerTask 'default', [
    'compile'
    'test'
  ]

