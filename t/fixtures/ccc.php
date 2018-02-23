<?php

class Ccc
{
    public static function doSomething()
    {
        Aaa::doSomething();
        Bbb::doSomething();
        Ccc::doSomething();
        self::doSomething();
        $this->doSomething();
    }

    public static function php_helps_programmers()
    {
        // This is a dummy definition to test proper use of taglist().
        // For example, taglist('A') returns tags matched to A,
        // but it returns also tags matched to Aaa.

        Ccc::php();
    }
}
