<?php

class Aaa
{
    public static function doSomething()
    {
        Aaa::doSomething();
        Bbb::doSomething();
        Ccc::doSomething();
        self::doSomething();
    }
}
