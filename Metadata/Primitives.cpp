#include "Primitive.h"
#include "Meta.h"

//Building Metadata for all primitive types:
DEFINE_PRIMITIVE(int);
DEFINE_PRIMITIVE(float);
DEFINE_PRIMITIVE(double);
DEFINE_PRIMITIVE(unsigned);
DEFINE_PRIMITIVE(bool);
DEFINE_PRIMITIVE(char);
DEFINE_PRIMITIVE(long);
DEFINE_PRIMITIVE(short);

REGISTER_META(Primitive);