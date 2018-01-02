redef exit_only_after_terminate = T;

global h: opaque of Broker::Store;
global expected_key_count = 4;
global key_count = 0;

function do_lookup(key: string)
	{
	when ( local res = Broker::get(h, key) )
		{
		++key_count;
		print "lookup", key, res;

		if ( key_count == expected_key_count )
			terminate();
		}
	timeout 10sec
		{ print "timeout", key; }
	}

event do_it()
	{
	when ( local res = Broker::keys(h) )
		{
		print "clone keys", res;

		if ( res?$result )
			{
			local i = Broker::set_iterator(res$result);

			while ( ! Broker::set_iterator_last(i) )
				{
				do_lookup(Broker::set_iterator_value(i) as string);
				Broker::set_iterator_next(i);
				}
			}
		}
	timeout 10sec
		{ print "timeout"; }
	}

event ready()
	{
	h = Broker::create_clone("mystore");
	schedule 1sec { do_it() };
	}

event bro_init()
	{
	Broker::subscribe("bro/event/ready");
	Broker::listen("127.0.0.1");
	}
