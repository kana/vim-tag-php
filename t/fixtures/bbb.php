<?php

class Bbb
{
    public static function doSomething()
    {
        Aaa::doSomething();
        Bbb::doSomething();
        Ccc::doSomething();
        self::doSomething();
    }
}
