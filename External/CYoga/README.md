# Yoga Layout C(++) library

Pulled from the `yoga` folder from https://github.com/facebook/yoga and rearranged in two folders to suit Swift C interop.

Files are duplicated in `src` and `include` to prevent altering too much of the include directives, but some are still modified.

The following C++-only header files have been removed from the `include` directory to prevent Swift from loading them:
- `BitUtils.h`
- `CompactValue.h`
- `Yoga-internal.h`
- `Utils.h`
- `YGConfig.h`
- `YGFloatOptional.h`
- `YGLayout.h`
- `log.h`

TODO: Clean that up once Swift C++ interop is fully stable
