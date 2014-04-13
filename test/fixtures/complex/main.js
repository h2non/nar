var args = process.argv

console.log(process.execPath)
console.log(args.slice(1).join('\n'))

if (args[2] === '--loop') {
  setInterval(function () {
    console.log('app running')
  }, 1000)
} else {
  setTimeout(function () {
    console.log('app exit')
  }, 1000)
}
