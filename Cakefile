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

option '-w', '--watch', 'Set up the compiler to watch for changes in the source. Works for "engine", "css" and "tests".'
    
task 'build', 'Alias for "build:release"', (options) ->
    invoke 'build:release'
    
task 'build:release', 'Bundles all tasks necessary for a full release build.', (options) ->
    invoke 'build:assets'
    invoke 'build:css'
    invoke 'build:frontend'
    invoke 'build:backend'
                    
task 'build:assets', 'Copy assets to public folder.', () ->
    console.log 'Copying files from assets/ to public/...'
    
    assets = [
        'index.html'
        'js/jquery-1.10.1.js'
        'js/jquery.color-2.1.2.js'
    ]
    
    for file in assets
        fs.createReadStream("assets/#{file}").pipe fs.createWriteStream "public/#{file}"
        
    console.log "Done."
    
task 'build:css', 'Compile Stylus files to CSS and deploy.', (options) ->
    if options.watch
        watch = '-w'
        console.log 'Watching styles/ for changes to keep public/css/ up-to-date...'
    else
        watch = ''
        console.log 'Compiling Stylus from styles/ to public/css/...'
    stylusProc = spawn stylus, [watch, '-o', 'public/css/', 'styles/']
    captureOutput(stylusProc)
    
task 'build:frontend', 'Compile frontend code to JavaScript.', (options) ->
    appFiles = [
        'jQueryPlugins'
        'ColorGenerator'
        'frontend'
    ]
    console.log 'Starting build from client/ to public/js/frontend.js...'
    console.log 'Concatenating source files...'
    appContents = new Array(remaining = appFiles.length)
    for file, index in appFiles then do (file, index) ->
        fs.readFile "client/#{file}.coffee", 'utf8', (err, fileContents) ->
            throw err if err
            appContents[index] = fileContents
            compile() if --remaining is 0
    compile = ->
        fs.writeFile 'public/js/frontend.coffee', appContents.join('\n\n'), 'utf8', (err) ->
            throw err if err
            console.log 'Compiling...'
            exec 'coffee -c public/js/frontend.coffee', (err, stdout, stderr) ->
                throw err if err
                console.log stdout + stderr
                fs.unlink 'public/js/frontend.coffee', (err) ->
                    throw err if err
                    console.log 'Done.'

task 'build:backend', 'Compile regex engine to JavaScript for client.', (options) ->
    appFiles = [
        'Guards'
        'Tokens/Token'
        'Tokens/Assertion'
        'Tokens/Character'
        'Tokens/CharacterClass'
        'Tokens/Disjunction'
        'Tokens/Group'
        'Tokens/Quantifier'
        'Tokens/Sequence'
        'Parser'
        'Regex'
    ]
    console.log 'Starting build from engine/coffee/ to public/js/vizard.js...'
    console.log 'Concatenating source files...'
    appContents = new Array remaining = appFiles.length
    for file, index in appFiles then do (file, index) ->
        fs.readFile "engine/coffee/#{file}.coffee", 'utf8', (err, fileContents) ->
            throw err if err
            appContents[index] = fileContents
            compile() if --remaining is 0
    compile = () ->
        fs.writeFile 'public/js/vizard.coffee', appContents.join('\n\n'), 'utf8', (err) ->
            throw err if err
            console.log 'Compiling...'
            exec 'coffee -c public/js/vizard.coffee', (err, stdout, stderr) ->
                throw err if err
                console.log stdout + stderr
                fs.unlink 'public/js/vizard.coffee', (err) ->
                    throw err if err
                    console.log 'Done.'

task 'build:engine', 'Compile regex engine to JavaScript for testing.', (options) ->
    if options.watch
        watch = '-w'
        console.log 'Watching engine/coffee/ for changes to keep engine/gen-js/ up-to-date...'
    else
        watch = ''
        console.log 'Compiling CoffeeScript from engine/coffee/ to engine/gen-js/...'
    coffeeProc = spawn coffee, ['-c', watch, '-o', 'engine/gen-js/', 'engine/coffee/']
    captureOutput(coffeeProc)
    
task 'build:tests', 'Compile test suite to JavaScript.', (options) ->
    if options.watch
        watch = '-w'
        console.log 'Watching tests/coffee/ for changes to keep tests/gen-js/ up-to-date...'
    else
        watch = ''
        console.log 'Compiling CoffeeScript from tests/coffee/ to tests/gen-js/...'
    coffeeProc = spawn coffee, ['-c', watch, '-o', 'tests/gen-js/', 'tests/coffee/']
    captureOutput(coffeeProc)
            
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