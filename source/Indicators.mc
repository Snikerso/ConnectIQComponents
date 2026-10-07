import Toybox.Graphics;
import Toybox.Math;

module ConnectIQComponents {
    // Extracted from the chips in KnittingCounter: capsule radius follows height.
    class Badge extends Label {
        function initialize(options, sharedTheme) { Label.initialize(options, sharedTheme); }
        function paint(dc, x, y, s) {
            dc.setColor(s[:surface], Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x, y, props[:width], props[:height], props[:height]/2);
            dc.setColor(s[:border], Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(s[:borderWidth]);
            dc.drawRoundedRectangle(x, y, props[:width], props[:height], props[:height]/2);
            dc.setPenWidth(1);
            Label.paint(dc, x, y, s);
        }
    }

    // TeaStop's quiet secondary action, with the same callbacks as Button.
    class OutlineButton extends Label {
        function initialize(options, sharedTheme) { Label.initialize(options, sharedTheme); }
        function paint(dc, x, y, s) {
            dc.setColor(s[:surface], Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x, y, props[:width], props[:height], s[:radius]);
            dc.setColor(props[:disabled] ? s[:muted] : s[:border], Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(s[:borderWidth]);
            dc.drawRoundedRectangle(x, y, props[:width], props[:height], s[:radius]);
            dc.setPenWidth(1);
            var textStyle = merge(s, {:foreground=>props[:disabled] ? s[:muted] : s[:accent]});
            Label.paint(dc, x, y, textStyle);
        }
    }

    // TeaStop's top rule; vertical variant is useful between side-by-side stats.
    class Divider extends Component {
        function initialize(options, sharedTheme) {
            Component.initialize(merge({:vertical=>false}, options), sharedTheme);
        }
        function paint(dc, x, y, s) {
            dc.setColor(s[:border], Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(s[:borderWidth]);
            if (props[:vertical]) {
                dc.drawLine(x + props[:width]/2, y, x + props[:width]/2, y + props[:height]);
            } else {
                dc.drawLine(x, y + props[:height]/2, x + props[:width], y + props[:height]/2);
            }
            dc.setPenWidth(1);
        }
    }

    // TeaStop's segmented timer ring. Timekeeping stays in the consuming app.
    class ProgressRing extends Component {
        function initialize(options, sharedTheme) {
            Component.initialize(merge({:value=>0.0, :ticks=>60, :startAngle=>-90}, options), sharedTheme);
        }
        function activeTicks() {
            var ticks = props[:ticks].toNumber();
            if (ticks < 1) { return 0; }
            var value = props[:value];
            if (value < 0) { value = 0; }
            if (value > 1) { value = 1; }
            return (ticks * value).toNumber();
        }
        function paint(dc, x, y, s) {
            var ticks = props[:ticks].toNumber();
            if (ticks < 1 || props[:width] <= 0 || props[:height] <= 0) { return; }
            var diameter = props[:width] < props[:height] ? props[:width] : props[:height];
            var thickness = s[:ringWidth];
            var length = s[:tickLength];
            if (thickness <= 0 || length <= 0) { return; }
            // Keep both the tick endpoints and stroke inside the component bounds.
            var outer = (diameter - thickness)/2.0;
            if (outer <= 0) { return; }
            var inner = outer - length;
            if (inner < 0) { inner = 0; }
            var cx = x + props[:width]/2;
            var cy = y + props[:height]/2;
            var active = activeTicks();
            dc.setPenWidth(thickness);
            for (var i = 0; i < ticks; i++) {
                var angle = (props[:startAngle] + i*360.0/ticks)*Math.PI/180.0;
                dc.setColor(i < active ? s[:accent] : s[:track], Graphics.COLOR_TRANSPARENT);
                dc.drawLine((cx + Math.cos(angle)*inner).toNumber(),
                    (cy + Math.sin(angle)*inner).toNumber(),
                    (cx + Math.cos(angle)*outer).toNumber(),
                    (cy + Math.sin(angle)*outer).toNumber());
            }
            dc.setPenWidth(1);
        }
    }
}
