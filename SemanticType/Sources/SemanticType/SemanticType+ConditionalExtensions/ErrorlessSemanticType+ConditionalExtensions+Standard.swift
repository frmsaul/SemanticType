extension SemanticType
    where
    Spec.BackingPrimitiveWithValueSemantics: Numeric,
    Spec.Error == Never
{
    public static func * (lhs: Self, rhs: Spec.BackingPrimitiveWithValueSemantics) -> Self {
        return Self(lhs.backingPrimitive * rhs)
    }

    public static func * (lhs: Self.Spec.BackingPrimitiveWithValueSemantics, rhs: Self) -> Self {
        Self(lhs * rhs.backingPrimitive)
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        lhs.backingPrimitive *= rhs.backingPrimitive
    }
}
