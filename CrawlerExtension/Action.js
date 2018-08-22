var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        var urls = new Array();
        // 所有标签
        var nodes = document.getElementsByTagName('*');
        console.log(nodes[49])
        // 免检测标签
        var disTag = ['br', 'hr', 'script', 'code', 'del', 'embed', 'frame', 'frameset', 'iframe', 'link', 'style', 'object', 'pre', 'video', 'wbr', 'xmp'];
        for (var i = 0, len = nodes.length; i < len; i++) {
            var node = nodes[i];
            if (disTag.indexOf(node.tagName) > -1) {
                continue;
            } else if (node.tagName.toLowerCase() == 'input' && (node.type == 'radio' || node.type == 'checkbox')) {
                continue;
            }
            console.log(node, i);
            if (node.tagName.toLowerCase() == 'img') {
                urls.push(node.src);
            } else {
                var bgImage;
                if (document.defaultView && document.defaultView.getComputedStyle) {
                    bgImage = document.defaultView.getComputedStyle(node, null).backgroundImage;
                } else {
                    bgImage = node.currentStyle.backgroundImage;
                }
                if (bgImage == 'none') {
                    continue;
                }
                var results = bgImage.match(/\burl\([^\)]+\)/gi);
                if (results == null || results.length <= 0) {
                    continue;
                }
                var bgSrc = results[0].replace(/\burl\(|\)/g, '').replace(/^\s+|\s+$/g, '');
                urls.push(bgSrc);
            }
        }
        arguments.completionFunction({"title": document.title, "URL": document.URL, "imageURLs": urls })
    },
    
    finalize: function(arguments) {}

};
    
var ExtensionPreprocessingJS = new Action
