//
//  main.cpp
//  Harmony
//
//  Created by Felipe Robledo on 4/8/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#include <iostream>
#include <functional>
#include <memory>

void printA() { std::cout << "A" << std::endl; }
void printB() { std::cout << "B" << std::endl; }
void printC() { std::cout << "C" << std::endl; }

template <typename T>
void caller(T arg)
{
    return arg();
}

template <typename T,typename... Args>
void caller(T first, Args... args)
{
    // __PRETTY_FUNCTION__ is not supported in al compilers, but it is
    //   used in gcc and clang for sure.
    std::cout << __PRETTY_FUNCTION__ << std::endl;
    first();
    caller(args...);
}

int main(int argc, const char * argv[]) {
    // insert code here...
    caller(printA,printB,printC);
    
    std::cout << "Hello, World!\n";
    return 0;
}
