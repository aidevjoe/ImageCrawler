var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        var urls = new Array();
        var nodes = document.body.getElementsByTagName('*');
        for (var i = 0, len1 = nodes.length; i < len1; i++) {
            if (nodes[i].tagName.toLowerCase() == 'img') {
                urls.push(nodes[i].src);
            }
        }
        arguments.completionFunction({"title": document.title, "URL": document.URL, "imageURLs": urls })
    },
    
    finalize: function(arguments) {}
    
//    getImages: function (arguments) {
//        var ulrs = []
//        var nodes = document.body.getElementsByTagName('*');
////        if (this.options.deep == 'img') {
//            for (var i = 0, len1 = nodes.length; i < len1; i++) {
//                if (nodes[i].tagName.toLowerCase() == 'img') {
//                    urls.push(nodes[i].src);
//                }
//            }
//        return urls
//        } else if (this.options.deep == 'all') {
//            for (var j = 0, len2 = nodes.length; j < len2; j++) {
//                if (this.isDisTag(nodes[j].tagName)) {
//                    continue;
//                } else if (nodes[j].tagName.toLowerCase() == 'input' && (nodes[j].type == 'radio' || nodes[j].type == 'checkbox')) {
//                    continue;
//                } else if (nodes[j].getAttribute('no-catch') !== null) {
//                    continue;
//                }
//                if (nodes[j].tagName.toLowerCase() == 'img' && nodes[j].getAttribute('no-catch') === null) {
//                    this.config.state[0] = false;
//                    this.config.queImg.push(nodes[j].src);
//                    this.config.total++;
//                } else {
//                    var bgImg = this.getBackgroundImage(nodes[j]);
//                    if (bgImg != 'none') {
//                        var bgRepeated = false;
//                        var bgSrc = bgImg.match(/\([^\)]+\)/g)[0].replace(/\(|\)/g, '').replace(/^\s+|\s+$/g,"");
//                        for (var k = 0; k < this.config.queBg.length; k++) {
//                            if (bgSrc == this.config.queBg[k]) {
//                                bgRepeated = true;
//                                break;
//                            }
//                        }
//                        if (!bgRepeated) {
//                            this.config.state[1] = false;
//                            this.config.queBg.push(bgSrc);
//                            this.config.total++;
//                        }
//                    }
//                }
//            }
//        }
//    },
    
//    selectedHTML: function() {
//        var range;
//        if (document.selection && document.selection.createRange) {
//            range = document.selection.createRange();
//            return range.htmlText;
//        } else if (window.getSelection) {
//            var selection = window.getSelection();
//            if (selection.rangeCount > 0) {
//                range = selection.getRangeAt(0);
//                var clonedSelection = range.cloneContents();
//                var div = document.createElement('div');
//                div.appendChild(clonedSelection);
//                return div.innerHTML;
//            } else {
//                return '';
//            }
//        } else {
//            return '';
//        }
//    }

};
    
var ExtensionPreprocessingJS = new Action
