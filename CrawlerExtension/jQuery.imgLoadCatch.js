/**
 * jQuery.imgLoadCatch.js v0.2.2
 * https://github.com/TevinLi/imgloadcatch
 *
 * Copyright 2015, Tevin Li
 * Released under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 */

;
(function ($, window, document) {

    'use strict';

    var Catch, init = false;

    Catch = (function () {
        return function (opt) {
            this.config = {
                //总图片数
                total: 0,
                //已处理计数
                count: 0,
                //已处理img计数
                countIMG: 0,
                //已处理bg计数
                countBg: 0,
                //img错误计数
                imgError: 0,
                //img错误计数
                bgError: 0,
                //是否完成状态
                state: [true, true],
                //img标签列队
                queImg: [],
                //背景列队
                queBg: [],
                //免检测标签
                disTag: ['br', 'hr', 'script', 'code', 'del', 'embed', 'frame', 'frameset', 'iframe', 'link',
                    'style', 'object', 'pre', 'video', 'wbr', 'xmp']
            };
            this.options = $.extend({
                deep: 'img',
                export: true,
                start: function () {
                },
                step: function () {
                },
                imgTag: function () {
                },
                finish: function () {
                }
            }, opt || {});
            this.init();
        };
    })();

    //获取所有图片，创建列队
    Catch.prototype.init = function () {
        var that = this;
        this.options.start();
        var nodes = document.body.getElementsByTagName('*');
        if (this.options.deep == 'img') {
            for (var i = 0, len1 = nodes.length; i < len1; i++) {
                if (nodes[i].tagName.toLowerCase() == 'img' && nodes[i].getAttribute('no-catch') === null) {
                    this.config.state[0] = false;
                    this.config.queImg.push(nodes[i].src);
                    this.config.total++;
                }
            }
        } else if (this.options.deep == 'all') {
            for (var j = 0, len2 = nodes.length; j < len2; j++) {
                if (this.isDisTag(nodes[j].tagName)) {
                    continue;
                } else if (nodes[j].tagName.toLowerCase() == 'input' && (nodes[j].type == 'radio' || nodes[j].type == 'checkbox')) {
                    continue;
                } else if (nodes[j].getAttribute('no-catch') !== null) {
                    continue;
                }
                if (nodes[j].tagName.toLowerCase() == 'img' && nodes[j].getAttribute('no-catch') === null) {
                    this.config.state[0] = false;
                    this.config.queImg.push(nodes[j].src);
                    this.config.total++;
                } else {
                    var bgImg = this.getBackgroundImage(nodes[j]);
                    if (bgImg != 'none') {
                        var bgRepeated = false;
                        var bgSrc = bgImg.match(/\([^\)]+\)/g)[0].replace(/\(|\)/g, '').replace(/^\s+|\s+$/g,"");
                        for (var k = 0; k < this.config.queBg.length; k++) {
                            if (bgSrc == this.config.queBg[k]) {
                                bgRepeated = true;
                                break;
                            }
                        }
                        if (!bgRepeated) {
                            this.config.state[1] = false;
                            this.config.queBg.push(bgSrc);
                            this.config.total++;
                        }
                    }
                }
            }
        }
    };

    //处理完成
    Catch.prototype.end = function () {
        var that = this;
        var end = function () {
            setTimeout(function () {
                that.options.finish({
                    total: that.config.total,
                    count: that.config.count,
                    countError: that.config.imgError + that.config.bgError,
                    countSuccess: that.config.count - (that.config.imgError + that.config.bgError),
                    imgTag: that.config.countIMG,
                    imgTagError: that.config.imgError,
                    imgTagSuccess: that.config.countIMG - that.config.imgError,
                    cssBg: that.config.countBg,
                    cssBgError: that.config.bgError,
                    cssBgSuccess: that.config.countBg - that.config.bgError
                });
            }, 100);
        };
        if (this.options.deep == 'img') {
            if (this.config.state[0]) {
                end();
            }
        } else if (this.options.deep == 'all') {
            if (this.config.state[0] && this.config.state[1]) {
                this.config.queBg = [];
                end();
            }
        }
    };

    //免检测判断
    Catch.prototype.isDisTag = function (tagName) {
        var tag = tagName.toLowerCase();
        var re = false;
        for (var i = 0; i < this.config.disTag.length; i++) {
            if (tag == this.config.disTag[i]) {
                re = true;
                break;
            }
        }
        return re;
    };

    //获取css背景
    Catch.prototype.getBackgroundImage = function (node) {
        if (document.defaultView && document.defaultView.getComputedStyle) {
            return document.defaultView.getComputedStyle(node, null).backgroundImage;
        } else {
            return node.currentStyle.backgroundImage;
        }
    };

    $.extend($, {
        imgLoadCatch: function (opt) {
            if (!init) {
                init = true;
                new Catch(opt);
            }
        }
    });

})($, window, document);
