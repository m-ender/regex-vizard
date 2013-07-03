fs            = require 'fs'
{print}       = require 'sys'
{spawn, exec} = require 'child_process'

# workaround because spawn does not read PATHEXT
if /^Windows/i.test require('os').type() 
    coffee = 'coffee.cmd'
    stylus = 'stylus.cmd'
else
    coffee = 'coffee'
    stylus = 'stylus'

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
    'Tokens/Token'
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
    
    'Frontend/jQueryPlugins'
    'Frontend/frontend'
]

option '-w', '--watch', 'Set up the compiler to watch for changes in the source. Does not work for "release" build.'
option '-e', '--environment [ENVIRONMENT_NAME]', 'Set the target environment for "build" task. Possible values: "release" (default), "debug", "tests" or "css"'

task 'build', 'Compile CoffeeScript to JavaScript', (options) ->
    switch options.environment or 'release'
        when 'debug'
            
            if options.watch
                watch = '-w'
                console.log 'Watching lib/ for changes to keep "debug" build up-to-date...'
            else
                watch = ''
                console.log 'Starting debug build to lib/...'
            coffeeProc = spawn coffee, ['-c', watch, '-o', 'lib', 'src']
            captureOutput(coffeeProc)
                
        when 'release'
            console.log 'Starting release build to public/js/...'
            console.log 'Concatenating source files...'
            appContents = new Array remaining = appFiles.length
            for file, index in appFiles then do (file, index) ->
                fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
                    throw err if err
                    appContents[index] = fileContents
                    compile() if --remaining is 0
            compile = ->
                fs.writeFile 'public/js/vizard.coffee', appContents.join('\n\n'), 'utf8', (err) ->
                    throw err if err
                    console.log 'Compiling...'
                    exec 'coffee -c public/js/vizard.coffee', (err, stdout, stderr) ->
                        throw err if err
                        console.log stdout + stderr
                        fs.unlink 'public/js/vizard.coffee', (err) ->
                            throw err if err
                            console.log 'Done.'
                            console.log 'CSS has not been built! Use "cake -e css build" if necessary.'
                            
        when 'tests'
            if options.watch
                watch = '-w'
                console.log 'Watching tests/src/ for changes to keep "tests" build up-to-date...'
            else
                watch = ''
                console.log 'Building tests...'
            coffeeProc = spawn coffee, ['-c', watch, '-o', 'tests', 'tests/src']
            captureOutput(coffeeProc)
            
        when 'css'
            if options.watch
                watch = '-w'
                console.log 'Watching styles/ for changes to keep "css" build up-to-date...'
            else
                watch = ''
                console.log 'Compiling css...'
            stylusProc = spawn stylus, [watch, '-o', 'public/css/', 'styles/']
            captureOutput(stylusProc)
            
        else
            console.log 'Unknown environment. Use "debug", "release" or "tests".'
            
task 'server', 'Start up HTTP server (on port 1618)', (options) ->
    server = spawn coffee, ['./server.coffee'], {cwd: undefined, env: process.env}
    captureOutput(server)
            
option '-t', '--tests [TEST_SELECTOR]', 'Regular expression to select tests to be run. Use "all" to run everything.'
            
task 'test', 'Run tests with jsTestDriver', (options) ->
    options.tests = options.tests or 'all'
    console.log 'Running tests...'
    test = spawn 'java', ['-jar', ".\\tools\\jsTestDriver\\JsTestDriver-1.3.5.jar", '--tests', options.tests, '--captureConsole'], {cwd: undefined, env: process.env}
    captureOutput(test)
    
option '-b', '--browsers', 'Open and capture all browsers after starting jsTestDriver.'

task 'driver', 'Starts up jsTestDriver', (options) ->
    port = options.port or '4224'
    browserOption = if options.browsers then '--browser' else ''
    browserArgument = if options.browsers then 'C:\\Users\\martin\\AppData\\Local\\Google\\Chrome\\Application\\chrome.exe,C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe,C:\\Program Files (x86)\\Safari\\Safari.exe,C:\\Program Files (x86)\\Opera\\opera.exe,C:\\Program Files\\Internet Explorer\\iexplore.exe' else ''
    console.log 'Starting up jsTestDriver...'
    driver = spawn 'java', ['-jar', ".\\tools\\jsTestDriver\\JsTestDriver-1.3.5.jar", '--port', port, browserOption, browserArgument]
    captureOutput(driver)