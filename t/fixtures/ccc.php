<?php

class Ccc
{
    public static function doSomething()
    {
        Aaa::doSomething();
        Bbb::doSomething();
        Ccc::doSomething();
        self::doSomething();
    }
}
