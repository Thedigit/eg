if (typeof PAYPAL == 'undefined' || !PAYPAL) {
    var PAYPAL = {};
}
PAYPAL.apps = PAYPAL.apps || {};
(function () {
    var defaultConfig = {
        trigger: null,
        expType: null,
        sole: 'true',
        stage: null,
        port: null
    };
    PAYPAL.apps.DGFlow = function (userConfig) {
        var that = this;
        that.UI = {};
        that._init(userConfig);
        return {
            setTrigger: function (el) {
                that._setTrigger(el);
            },
            startFlow: function (url) {
                var win = that._render();
                if (win.location) {
                    win.location = url;
                } else {
                    win.src = url;
                }
            },
            closeFlow: function () {
                that._destroy();
            },
            isOpen: function () {
                return that.isOpen;
            }
        };
    };
    PAYPAL.apps.DGFlow.prototype = {
        name: 'PPDGFrame',
        isOpen: false,
        NoB: true,
        _init: function (userConfig) {
            if (userConfig) {
                for (var key in defaultConfig) {
                    if (typeof userConfig[key] !== 'undefined') {
                        this[key] = userConfig[key];
                    } else {
                        this[key] = defaultConfig[key];
                    }
                }
            }
            this.port = (this.port == null) ? "" : ":" + this.port;
            this.stage = (this.stage == null) ? "www.paypal.com" : "www." + this.stage + ".paypal.com" + this.port;
            if (this.trigger) {
                this._setTrigger(this.trigger);
            }
            this._addCSS();
            if (this.NoB == true && this.sole == 'true') {
                var url = "https://" + this.stage + "/webapps/checkout/nameOnButton.gif";
                this._getImage(url, this._addImage);
            }
        },
        _render: function () {
            var ua = navigator.userAgent,
                win;
            if (ua.match(/iPhone|iPod|Android|Blackberry.*WebKit/i)) {
                win = window.open('', this.name);
                return win;
            } else if (this.expType == 'mini') {
                var width = 400,
                    height = 550,
                    left, top;
                if (window.outerWidth) {
                    left = Math.round((window.outerWidth - width) / 2) + window.screenX;
                    top = Math.round((window.outerHeight - height) / 2) + window.screenY;
                } else if (window.screen.width) {
                    left = Math.round((window.screen.width - width) / 2);
                    top = Math.round((window.screen.height - height) / 2);
                }
                win = window.open('', this.name, 'top=' + top + ', left=' + left + ', width=' + width + ', height=' + height + ', location=0, status=0, toolbar=0, menubar=0, resizable=0');
                return win;
            } else {
                this._buildDOM();
                this._createMask();
                this._centerLightbox();
                this._bindEvents();
                this.isOpen = true;
                return this.UI.iframe;
            }
        },
        _addCSS: function () {
            var css = '',
                styleEl = document.createElement('style');
            css += '#' + this.name + ' { z-index:20002; position:absolute; top:0; left:0; }';
            css += '#' + this.name + ' .panel { z-index:20003; position:relative; }';
            css += '#' + this.name + ' .panel iframe { width:385px; height:550px; border:0; }';
            css += '#' + this.name + ' .mask { z-index:20001; position:absolute; top:0; left:0; background-color:#000; opacity:0.2; filter:alpha(opacity=20); }';
            css += '.nameOnButton { display: inline-block; text-align: center; }';
            css += '.nameOnButton img { border:none; }';
            styleEl.type = 'text/css';
            if (styleEl.styleSheet) {
                styleEl.styleSheet.cssText = css;
            } else {
                styleEl.appendChild(document.createTextNode(css));
            }
            document.getElementsByTagName('head')[0].appendChild(styleEl);
        },
        _buildDOM: function () {
            this.UI.wrapper = document.createElement('div');
            this.UI.wrapper.id = this.name;
            this.UI.panel = document.createElement('div');
            this.UI.panel.className = 'panel';
            try {
                this.UI.iframe = document.createElement('<iframe name="' + this.name + '">');
            } catch (e) {
                this.UI.iframe = document.createElement('iframe');
                this.UI.iframe.name = this.name;
            }
            this.UI.iframe.frameBorder = '0';
            this.UI.iframe.border = '0';
            this.UI.iframe.scrolling = 'no';
            this.UI.iframe.allowTransparency = 'true';
            this.UI.mask = document.createElement('div');
            this.UI.mask.className = 'mask';
            this.UI.panel.appendChild(this.UI.iframe);
            this.UI.wrapper.appendChild(this.UI.mask);
            this.UI.wrapper.appendChild(this.UI.panel);
            document.body.appendChild(this.UI.wrapper);
        },
        _createMask: function (e) {
            var windowWidth, windowHeight, scrollWidth, scrollHeight, width, height;
            if (window.innerHeight && window.scrollMaxY) {
                scrollWidth = window.innerWidth + window.scrollMaxX;
                scrollHeight = window.innerHeight + window.scrollMaxY;
            } else if (document.body.scrollHeight > document.body.offsetHeight) {
                scrollWidth = document.body.scrollWidth;
                scrollHeight = document.body.scrollHeight;
            } else {
                scrollWidth = document.body.offsetWidth;
                scrollHeight = document.body.offsetHeight;
            }
            if (window.innerHeight) {
                windowWidth = window.innerWidth;
                windowHeight = window.innerHeight;
            } else if (document.documentElement && document.documentElement.clientHeight) {
                windowWidth = document.documentElement.clientWidth;
                windowHeight = document.documentElement.clientHeight;
            } else if (document.body) {
                windowWidth = document.body.clientWidth;
                windowHeight = document.body.clientHeight;
            }
            width = (windowWidth > scrollWidth) ? windowWidth : scrollWidth;
            height = (windowHeight > scrollHeight) ? windowHeight : scrollHeight;
            this.UI.mask.style.width = width + 'px';
            this.UI.mask.style.height = height + 'px';
        },
        _centerLightbox: function (e) {
            var width, height, scrollY;
            if (window.innerWidth) {
                width = window.innerWidth;
                height = window.innerHeight;
                scrollY = window.pageYOffset;
            } else if (document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight)) {
                width = document.documentElement.clientWidth;
                height = document.documentElement.clientHeight;
                scrollY = document.documentElement.scrollTop;
            } else if (document.body && (document.body.clientWidth || document.body.clientHeight)) {
                width = document.body.clientWidth;
                height = document.body.clientHeight;
                scrollY = document.body.scrollTop;
            }
            this.UI.panel.style.left = Math.round((width - this.UI.iframe.offsetWidth) / 2) + 'px';
            var panelTop = Math.round((height - this.UI.iframe.offsetHeight) / 2) + scrollY;
            if (panelTop < 5) {
                panelTop = 10;
            }
            this.UI.panel.style.top = panelTop + 'px';
        },
        _bindEvents: function () {
            addEvent(window, 'resize', this._createMask, this);
            addEvent(window, 'resize', this._centerLightbox, this);
            addEvent(window, 'unload', this._destroy, this);
        },
        _setTrigger: function (el) {
            if (el.constructor.toString().indexOf('Array') > -1) {
                for (var i = 0; i < el.length; i++) {
                    this._setTrigger(el[i]);
                }
            } else {
                el = (typeof el == 'string') ? document.getElementById(el) : el;
                if (el && el.form) {
                    el.form.target = this.name;
                } else if (el && el.tagName.toLowerCase() == 'a') {
                    el.target = this.name;
                }
                addEvent(el, 'click', this._triggerClickEvent, this);
            }
        },
        _getImage: function (url, callback) {
            if (typeof this.callback != 'undefined') {
                url = this.url;
                callback = this.callback;
            }
            var self = this;
            var imgElement = new Image();
            imgElement.src = "";
            if (imgElement.readyState) {
                imgElement.onreadystatechange = function () {
                    if (imgElement.readyState == 'complete' || imgElement.readyState == 'loaded') {
                        callback(imgElement, self);
                    }
                };
            } else {
                imgElement.onload = function () {
                    callback(imgElement, self);
                };
            }
            imgElement.src = url;
        },
        _addImage: function (img, obj) {
            if (checkEmptyImage(img)) {
                var url = "https://" + obj.stage + "/webapps/checkout/clearNob.gif";
                var wrapperObj = {};
                wrapperObj.callback = obj._removeImage;
                wrapperObj.url = url;
                wrapperObj.outer = obj;
                var el = obj.trigger;
                if (el.constructor.toString().indexOf('Array') > -1) {
                    for (var i = 0; i < el.length; i++) {
                        var tempImg = img.cloneNode(true);
                        obj._placeImage(el[i], tempImg, wrapperObj);
                    }
                } else {
                    obj._placeImage(el, img, wrapperObj);
                }
            }
        },
        _placeImage: function (el, img, obj) {
            el = (typeof el == 'string') ? document.getElementById(el) : el;
            var root = getParent(el);
            var spanElement = document.createElement("span");
            spanElement.className = "nameOnButton";
            var lineBreak = document.createElement("br");
            var link = document.createElement("a");
            link.href = "javascript:";
            link.appendChild(img);
            root.insertBefore(spanElement, el);
            spanElement.appendChild(el);
            spanElement.insertBefore(link, el);
            spanElement.insertBefore(lineBreak, el);
            obj.span = spanElement;
            obj.link = link;
            obj.lbreak = lineBreak;
            addEvent(link, 'click', obj.outer._getImage, obj);
        },
        _removeImage: function (img, obj) {
            if (!checkEmptyImage(img)) {
                var el = obj.outer.trigger;
                if (el.constructor.toString().indexOf('Array') > -1) {
                    obj.outer._removeMultiImages(obj.outer.trigger);
                } else {
                    spanElement = obj.span;
                    link = obj.link;
                    lineBreak = obj.lbreak;
                    spanElement.removeChild(link);
                    spanElement.removeChild(lineBreak);
                }
            }
        },
        _removeMultiImages: function (obj) {
            for (var i = 0; i < obj.length; i++) {
                obj[i] = (typeof obj[i] == 'string') ? document.getElementById(obj[i]) : obj[i];
                rootNode = getParent(obj[i]);
                if (rootNode.className == 'nameOnButton') {
                    lineBreak = getPreviousSibling(obj[i]);
                    linkNode = getPreviousSibling(lineBreak);
                    rootNode.removeChild(linkNode);
                    rootNode.removeChild(lineBreak);
                }
            }
        },
        _triggerClickEvent: function (e) {
            this._render();
        },
        _destroy: function (e) {
            if (this.isOpen && this.UI.wrapper.parentNode) {
                this.UI.wrapper.parentNode.removeChild(this.UI.wrapper);
            }
            if (this.interval) {
                clearInterval(this.interval);
            }
            removeEvent(window, 'resize', this._createMask);
            removeEvent(window, 'resize', this._centerLightbox);
            removeEvent(window, 'unload', this._destroy);
            removeEvent(window, 'message', this._windowMessageEvent);
            this.isOpen = false;
        }
    };
    var eventCache = [];

    function addEvent(obj, type, fn, scope) {
        scope = scope || obj;
        var wrappedFn;
        if (obj.addEventListener) {
            wrappedFn = function (e) {
                fn.call(scope, e);
            };
            obj.addEventListener(type, wrappedFn, false);
        } else if (obj.attachEvent) {
            wrappedFn = function () {
                var e = window.event;
                e.target = e.target || e.srcElement;
                e.preventDefault = function () {
                    window.event.returnValue = false;
                };
                fn.call(scope, e);
            };
            obj.attachEvent('on' + type, wrappedFn);
        }
        eventCache.push([obj, type, fn, wrappedFn]);
    }

    function removeEvent(obj, type, fn) {
        var wrappedFn, item, len, i;
        for (i = 0; i < eventCache.length; i++) {
            item = eventCache[i];
            if (item[0] == obj && item[1] == type && item[2] == fn) {
                wrappedFn = item[3];
                if (wrappedFn) {
                    if (obj.removeEventListener) {
                        obj.removeEventListener(type, wrappedFn, false);
                    } else if (obj.detachEvent) {
                        obj.detachEvent('on' + type, wrappedFn);
                    }
                }
            }
        }
    }

    function getParent(el) {
        do {
            el = el.parentNode;
        } while (el && el.nodeType != 1);
        return el;
    }

    function getPreviousSibling(el) {
        do {
            el = el.previousSibling;
        } while (el && el.nodeType != 1);
        return el;
    }

    function checkEmptyImage(img) {
        return (img.width > 1 || img.height > 1);
    }
}());