package utils.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

class Macro {
	macro public static function getTypedObject(obj:Expr, typePath:Expr):Expr {
		final type = Context.getType(typePath.toString());
		switch (type.follow()) {
			case TAnonymous(_.get() => td):
				final name = obj.toString();
				if (obj.expr.match(EObjectDecl(_))) {
					throw new Error('$name should be passed as reference (inside of variable)', obj.pos);
				}
				final e:Expr = {
					expr: EObjectDecl([
						for (field in td.fields) {
							field: field.name,
							expr: macro $p{['$name', '${field.name}']},
						}
					]),
					pos: Context.currentPos()
				}
				return e;
			default:
				throw new Error(type.toString() + " should be typedef structure", typePath.pos);
		}
	}

	macro public static function getBuildTime():Expr {
		return macro $v{Date.now().toString()};
	}
}
