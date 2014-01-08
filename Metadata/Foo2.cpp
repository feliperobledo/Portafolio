#include "Foo2.h"

//Required definition of the declared Metasingleton for Foo
//DECLARE_META(Foo2);
//DECLARE_META(Foo3);

DEFINE_META(Foo2, META_TYPE(Foo));
REGISTER_META(Foo2);

DEFINE_META(Foo3, META_TYPE(Foo2));
REGISTER_META(Foo3);