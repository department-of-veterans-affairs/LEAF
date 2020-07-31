if (FileReader.prototype.readAsBinaryString === undefined) {
    FileReader.prototype.readAsBinaryString = function (fileData) {
        var binary = "";
        var pt = this;
        var reader = new FileReader();
        reader.onload = function (e) {
            var bytes = new Uint8Array(reader.result);
            var length = bytes.byteLength;
            for (var i = 0; i < length; i++) {
                binary += String.fromCharCode(bytes[i]);
            }
            //pt.result  - readonly so assign content to another property
            pt.content = binary;
            pt.onload(); // thanks to @Denis comment
        }
        reader.readAsArrayBuffer(fileData);
    }
}


function WorkbookHelper(upload){

    this.upload = upload;

    this.getHeaders = function(){
        return this.getData(0, 0)[0];
    }

    this.init = function(sheetNumber){
       
        if(!sheetNumber){
            sheetNumber = 0;
        }
        var helper = this;
        return new Promise(function(resolve){
            var fileReader = new FileReader();
    
            fileReader.onload = function (event) {    
                
                if(!event){
                    var data = this.content;
                }
                else{
                    var data = event.target.result; 
                }
                
                helper.workbook = XLSX.read(data, {type:"binary"});
                helper.sheet = helper.workbook.Sheets[helper.workbook.SheetNames[sheetNumber]];
                resolve();
            };
            fileReader.readAsBinaryString(helper.upload);
        })
    }
    
    
    this.getData = function(indexRowStart, indexRowEnd){
        
        var rowNum;
        var colNum;
    
        var results = [];
        var range = XLSX.utils.decode_range(this.sheet['!ref']);
    
        if(indexRowStart == undefined){
            indexRowStart = 0;
        }
        
        if(indexRowEnd == undefined){
            indexRowEnd = range.e.r;
        }
        else{
            indexRowEnd = (indexRowEnd > range.e.r) ? range.e.r :indexRowEnd;
        }

        for(rowNum = indexRowStart; rowNum <= indexRowEnd; rowNum++){
           
            for(colNum=range.s.c; colNum<=range.e.c; colNum++){
    
                var nextCell = this.sheet[
                    XLSX.utils.encode_cell({r: rowNum, c: colNum})
                ];

                if(nextCell){
                    var cellText = nextCell.w;
                    cellText = (cellText == undefined) ? '': cellText;
                    

                    if(!results[rowNum - indexRowStart]){
                        results[rowNum - indexRowStart] = [];
                    }
                    results[rowNum - indexRowStart][colNum] = cellText;
                }
            }
        }
        return results;
    }
}




function Header(text, index){
    this.text = text;
    this.index = index;
}


