import Toybox.Graphics;
import Toybox.WatchUi;

// Values are copied so local overrides never mutate the shared theme.
module ConnectIQComponents {
    function merge(base, overrides) {
        var result = {};
        var keys = base.keys();
        for (var i = 0; i < keys.size(); i++) { result[keys[i]] = base[keys[i]]; }
        if (overrides != null) {
            keys = overrides.keys();
            for (var j = 0; j < keys.size(); j++) { result[keys[j]] = overrides[keys[j]]; }
        }
        return result;
    }

    class Theme {
        var values;
        function initialize(overrides) {
            values = merge({:background=>0x101820, :surface=>0x243340,
                :foreground=>0xFFFFFF, :accent=>0x38BDF8, :muted=>0x94A3B8,
                :border=>0x475569, :borderWidth=>1, :track=>0x243340,
                :ringWidth=>3, :tickLength=>6,
                :radius=>12, :padding=>8, :font=>Graphics.FONT_SMALL}, overrides);
        }
    }

    // Bounds are local to the parent. All dimensions are pixels.
    class Component {
        var props;
        var theme;
        var children;
        function initialize(options, sharedTheme) {
            theme = sharedTheme == null ? new Theme(null) : sharedTheme;
            props = merge({:x=>0, :y=>0, :width=>100, :height=>40,
                :visible=>true, :disabled=>false, :style=>{}, :onPress=>null}, options);
            children = [];
        }
        function setProps(options) { props = merge(props, options); }
        function add(child) { children.add(child); return self; }
        function style() { return merge(theme.values, props[:style]); }
        function draw(dc, parentX, parentY) {
            if (!props[:visible]) { return; }
            var x = parentX + props[:x];
            var y = parentY + props[:y];
            paint(dc, x, y, style());
            for (var i = 0; i < children.size(); i++) { children[i].draw(dc, x, y); }
        }
        function paint(dc, x, y, s) {}
        function press(px, py, parentX, parentY) {
            if (!props[:visible] || props[:disabled]) { return false; }
            var x = parentX + props[:x];
            var y = parentY + props[:y];
            // Reverse order follows the drawing order (topmost child first).
            for (var i = children.size() - 1; i >= 0; i--) {
                if (children[i].press(px, py, x, y)) { return true; }
            }
            if (px >= x && py >= y && px < x + props[:width] && py < y + props[:height]) {
                var callback = props[:onPress];
                if (callback != null) { callback.invoke(); return true; }
            }
            return false;
        }
    }

    function fitText(dc, text, font, width) {
        if (width <= 0) { return ""; }
        if (dc.getTextWidthInPixels(text, font) <= width) { return text; }
        for (var n = text.length(); n > 0; n--) {
            var shortened = text.substring(0, n - 1) + "...";
            if (dc.getTextWidthInPixels(shortened, font) <= width) { return shortened; }
        }
        return "";
    }

    class Label extends Component {
        function initialize(options, sharedTheme) {
            Component.initialize(merge({:text=>""}, options), sharedTheme);
        }
        function paint(dc, x, y, s) {
            dc.setColor(s[:foreground], Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + props[:width]/2, y + props[:height]/2, s[:font],
                fitText(dc, props[:text], s[:font], props[:width] - 2*s[:padding]),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    class Panel extends Component {
        function initialize(options, sharedTheme) { Component.initialize(options, sharedTheme); }
        function paint(dc, x, y, s) {
            dc.setColor(s[:surface], Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x, y, props[:width], props[:height], s[:radius]);
        }
    }

    class Button extends Label {
        function initialize(options, sharedTheme) { Label.initialize(options, sharedTheme); }
        function paint(dc, x, y, s) {
            dc.setColor(props[:disabled] ? s[:muted] : s[:accent], Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x, y, props[:width], props[:height], s[:radius]);
            Label.paint(dc, x, y, s);
        }
    }

    class ProgressBar extends Component {
        function initialize(options, sharedTheme) {
            Component.initialize(merge({:value=>0.0}, options), sharedTheme);
        }
        function paint(dc, x, y, s) {
            var value = props[:value];
            if (value < 0) { value = 0; }
            if (value > 1) { value = 1; }
            dc.setColor(s[:surface], Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x, y, props[:width], props[:height], s[:radius]);
            var width = (props[:width] * value).toNumber();
            if (width > 0) {
                dc.setColor(s[:accent], Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(x, y, width, props[:height], s[:radius]);
            }
        }
    }

    class ComponentView extends WatchUi.View {
        var root;
        var viewTheme;
        function initialize(component, sharedTheme) {
            View.initialize();
            root = component;
            viewTheme = sharedTheme;
        }
        function onUpdate(dc) {
            dc.setColor(viewTheme.values[:background], viewTheme.values[:background]);
            dc.clear();
            root.draw(dc, 0, 0);
        }
        function onPressAt(x, y) {
            var handled = root.press(x, y, 0, 0);
            if (handled) { WatchUi.requestUpdate(); }
            return handled;
        }
    }

    class ComponentDelegate extends WatchUi.BehaviorDelegate {
        var view;
        var primaryAction;
        function initialize(componentView, onSelect) {
            BehaviorDelegate.initialize();
            view = componentView;
            primaryAction = onSelect;
        }
        function onTap(event) {
            var point = event.getCoordinates();
            return view.onPressAt(point[0], point[1]);
        }
        function onSelect() {
            if (primaryAction != null) {
                primaryAction.invoke();
                WatchUi.requestUpdate();
                return true;
            }
            return false;
        }
    }
}
