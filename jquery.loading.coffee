class $.Loading

    # クラスメンバ
    @event =
        RESET:"orientationchange resize"

    @TIMEOUT = 30
    @DEF_NAME = "none"

    @start = (name = Loading.DEF_NAME)->
        instance = Loading.instances[name]
        instance.$canvas.addClass "start"
        window.setTimeout(
            ->
                instance.$target.css 
                    visibility:"hidden"
                    display:"block"
                instance._setPosition()
                instance.$target.css "visibility", "visible"
                instance.isLoading = true
            , Loading.TIMEOUT
        )
        @

    @stop = (name = Loading.DEF_NAME)->
        instance = Loading.instances[name]
        instance.$canvas.removeClass "start"
        window.setTimeout(
            ->
                instance.$target.css
                    display:"none"
                instance.isLoading = false
                @
            , Loading.TIMEOUT
        )
        @

    @reset = ->
        Loading.instances = {}
        Loading.instances[Loading.DEF_NAME] = null;
        @

    Loading.reset()
    
    constructor:($target)->
        @$target = $target
        @cc = null
        @$canvas = null
        @isLoading = false
        @option = 
            name:Loading.DEF_NAME
            type:"arc"
            width:27
            height:27
            radius:3
            num:24
            color:"85, 85, 85"
            offset:0
            left:"center"
            top:"center"

    # インスタンスメソッド
    $.extend Loading.prototype,
        # オプションを継承
        _setOption:(option)->
            if option == undefined
                return
            $.extend @option, option
            @
        _init:->
            @$canvas = $ "<canvas></canvas>"
            canvas = @$canvas.get 0
            @$canvas.prop 
                width:@option.width
                height:@option.height
            @cc = canvas.getContext "2d"
            @$target.append canvas
            @$target.css "position", "absolute"
            switch @option.type
                when "arc"
                    @_drawArcs @option.num
                else
            Loading.stop(@option.name)
            $(window).on Loading.event.RESET, =>
                @_setPosition()
                @
            @
        _setPosition:->
            left = @option.left;
            top = @option.top;
            $parent = @$target.parent();
            if left == "center"
                left = ($parent.innerWidth() - @$target.innerWidth()) * 0.5 + "px"
            if top == "center"
                top = ($parent.innerHeight() - @$target.innerHeight()) * 0.5 + "px"
            @$target.css
                top:top
                left:left
            @
        _drawArcs:(num)->
            rad = 2 * Math.PI / num
            min = 1 / num
            radius = @option.radius
            offsetX = @option.width * 0.5
            offsetY = @option.height * 0.5
            offsetR = offsetX - radius
            i = 0
            while num > i
                @_drawArc (Math.cos rad*i)*offsetR+offsetX,
                    (Math.sin rad*i)*offsetR+offsetY,
                    radius,
                    @option.color
                    min * i + @option.offset
                i++
            @
        _drawArc:(x, y, radius, color, a)->
            @cc.beginPath()
            @cc.fillStyle = "rgba(" + color + ", " + a + ")"
            @cc.arc x, y, radius, 0, 2 * Math.PI, false
            @cc.fill()
            @cc.restore()
            @cc.save()
            @

    $.fn.loading = (option = {name:"none"})->
        @each ->
            option.name ?= "none"
            Loading.instances[option.name] = new Loading $ @
            Loading.instances[option.name]._setOption option
            Loading.instances[option.name]._init()
            @