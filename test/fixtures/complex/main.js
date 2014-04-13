var args = process.argv

console.log(args.join('\n'))

if (args[2] === '--infinite') {
  setInterval(function () {
    console.log('App running!')
  }, 2000)
}
