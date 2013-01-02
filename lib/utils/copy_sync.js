var fs = require('fs');

// function: copy_sync
// synchronously copy a single file
// 
//   - src: source file
//   - dest: where the file will end up

module.exports = function(src, dest){
  BUF_LENGTH = 64*1024;
  buff = new Buffer(BUF_LENGTH);
  fdr = fs.openSync(src, 'r');
  fdw = fs.openSync(dest, 'w');
  bytesRead = 1; pos = 0;

  while (bytesRead > 0) {
    bytesRead = fs.readSync(fdr, buff, 0, BUF_LENGTH, pos)
    fs.writeSync(fdw,buff,0,bytesRead)
    pos += bytesRead
  }

  fs.closeSync(fdr);
  fs.closeSync(fdw);
}