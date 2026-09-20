#pragma once

#include "ChordTypes.h"

namespace opian
{

class ChordEngine
{
public:
    ChordResult resolve (const ChordRequest& request) const;

    static int layoutDegreePc (const ChordRequest& request) noexcept;
};

} // namespace opian
