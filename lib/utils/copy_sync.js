// small utility to synchronously copy a single file

var fs = require('fs');

module.exports = function(srcFile, destFile){
  BUF_LENGTH = 64*1024;
  buff = new Buffer(BUF_LENGTH);
  fdr = fs.openSync(srcFile, 'r');
  fdw = fs.openSync(destFile, 'w');
  bytesRead = 1; pos = 0;

  while (bytesRead > 0) {
    bytesRead = fs.readSync(fdr, buff, 0, BUF_LENGTH, pos)
    fs.writeSync(fdw,buff,0,bytesRead)
    pos += bytesRead
  }

  fs.closeSync(fdr);
  fs.closeSync(fdw);
}