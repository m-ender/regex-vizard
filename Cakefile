fs            = require 'fs'
{print}       = require 'sys'
{spawn, exec} = require 'child_process'

captureOutput = (prog) ->
    prog.stderr.on 'data', (data) ->
        console.log data.toString()
    prog.stdout.on 'data', (data) ->
        print data.toString()
    prog.on 'exit', (code) ->
        if code isnt 0
            console.log "Application terminated with code #{code}"
        else
            console.log 'Done.'

appFiles = [
    'Token'
    'Tokens/Assertion'
    'Tokens/Character'
    'Tokens/CharacterClass'
    'Tokens/Disjunction'
    'Tokens/Group'
    'Tokens/Quantifier'
    'Tokens/Sequence'
    'Guards'
    'Parser'
    'Regex'
]

option '-w', '--watch', 'Set up the compiler to watch for changes in the source. Does not work for "release" build.'
option '-e', '--environment [ENVIRONMENT_NAME]', 'Set the target environment for "build" task. Possible values: "debug", "release", or "tests"'

task 'build', 'Compile CoffeeScript to JavaScript', (options) ->
    switch options.environment or 'release'
        when 'debug'
            
            if options.watch
                watch = '-w'
                console.log 'Watching lib/ for changes to keep "debug" build up-to-date...'
            else
                watch = ''
                console.log 'Starting debug build to lib/...'
            # workaround because spawn does not read PATHEXT
            if /^Windows/i.test require('os').type() 
                ext = '.cmd'
            else
                ext = ''
            coffee = spawn "coffee#{ext}", ['-c', watch, '-o', 'lib', 'src']
            captureOutput(coffee)
                
        when 'release'
            console.log 'Starting release build to html/js/...'
            console.log 'Concatenating source files...'
            appContents = new Array remaining = appFiles.length
            for file, index in appFiles then do (file, index) ->
                fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
                    throw err if err
                    appContents[index] = fileContents
                    compile() if --remaining is 0
            compile = ->
                fs.writeFile 'html/js/vizard.coffee', appContents.join('\n\n'), 'utf8', (err) ->
                    throw err if err
                    console.log 'Compiling...'
                    exec 'coffee -c html/js/vizard.coffee', (err, stdout, stderr) ->
                        throw err if err
                        console.log stdout + stderr
                        fs.unlink 'html/js/vizard.coffee', (err) ->
                            throw err if err
                            console.log 'Done.'
                            
        when 'tests'
            if options.watch
                watch = " -w"
                console.log 'Watching tests/ for changes to keep "tests" build up-to-date...'
            else
                watch = ""
                console.log 'Building tests...'
            exec "coffee -c#{watch} -o tests tests/src", (err, stdout, stderr) ->
                throw err if err
                console.log stdout + stderr
                console.log 'Done.'
        else
            console.log 'Unknown environment. Use "debug", "release" or "tests".'
            
option '-t', '--tests [TEST_SELECTOR]', 'Regular expression to select tests to be run. Use "all" to run everything.'
            
task 'test', 'Run tests with jsTestDriver', (options) ->
    options.tests = options.tests or 'all'
    console.log 'Running tests...'
    test = spawn 'java', ['-jar', "#{process.env.JSTESTDRIVER_DIR}\\JsTestDriver-1.3.5.jar", '--tests', options.tests, '--captureConsole'], {cwd: undefined, env: process.env}
    captureOutput(test)