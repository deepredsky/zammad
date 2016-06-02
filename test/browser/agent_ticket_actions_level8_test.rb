# encoding: utf-8
require 'browser_test_helper'

class AgentTicketActionLevel8Test < TestCase
  def test_a_tags

    @browser = browser_instance
    login(
      username: 'agent1@example.com',
      password: 'test',
      url: browser_url,
    )
    tasks_close_all()

    # set tag (by tab)
    ticket1 = ticket_create(
      data: {
        customer: 'nico',
        group: 'Users',
        title: 'some subject 123äöü - tags 1',
        body: 'some body 123äöü - tags 1',
      },
      do_not_submit: true,
    )
    sleep 1
    set(
      css: '.active .ticket-form-bottom .token-input',
      value: 'tag1, tag2',
    )
    sendkey(value: :tab)

    # reload browser
    sleep 6
    reload()
    sleep 2

    click(
      css: '.active .newTicket button.js-submit',
    )
    sleep 5
    if @browser.current_url !~ /#{Regexp.quote('#ticket/zoom/')}/
      raise 'Unable to create ticket!'
    end

    # verify tags
    tags_verify(
      tags: {
        'tag1' => true,
        'tag2' => true,
        'tag3' => false,
        'tag4' => false,
      }
    )

    # set tag (by blur)
    ticket2 = ticket_create(
      data: {
        customer: 'nico',
        group: 'Users',
        title: 'some subject 123äöü - tags 2',
        body: 'some body 123äöü - tags 2',
      },
      do_not_submit: true,
    )
    sleep 1
    set(
      css: '.active .ticket-form-bottom .token-input',
      value: 'tag3, tag4',
    )
    click(css: '#global-search')
    click(css: '.active .newTicket button.js-submit')
    sleep 5
    if @browser.current_url !~ /#{Regexp.quote('#ticket/zoom/')}/
      raise 'Unable to create ticket!'
    end

    # verify tags
    tags_verify(
      tags: {
        'tag1' => false,
        'tag2' => false,
        'tag3' => true,
        'tag4' => true,
      }
    )

    ticket3 = ticket_create(
      data: {
        customer: 'nico',
        group: 'Users',
        title: 'some subject 123äöü - tags 3',
        body: 'some body 123äöü - tags 3',
      },
    )

    # set tag #1
    click(
      css: '.content.active .js-newTagLabel',
    )
    set(
      css: '.content.active .js-newTagInput',
      value: 'tag1',
    )
    sendkey(
      value: :enter,
    )
    sleep 0.5

    # set tag #2
    click(
      css: '.content.active .js-newTagLabel',
    )
    set(
      css: '.content.active .js-newTagInput',
      value: 'tag 2',
    )
    sendkey(
      value: :enter,
    )
    sleep 0.5

    # set tag #3 + #4
    click(
      css: '.content.active .js-newTagLabel',
    )
    set(
      css: '.content.active .js-newTagInput',
      value: 'tag3, tag4',
    )
    sendkey(
      value: :enter,
    )
    sleep 0.5

    # set tag #5
    click(
      css: '.content.active .js-newTagLabel',
    )
    set(
      css: '.content.active .js-newTagInput',
      value: 'tag5',
    )
    click(
      css: '#global-search',
    )
    sleep 0.5

    # verify tags
    tags_verify(
      tags: {
        'tag1' => true,
        'tag 2' => true,
        'tag2' => false,
        'tag3' => true,
        'tag4' => true,
        'tag5' => true,
      }
    )

    # reload browser
    reload()
    sleep 2

    # verify tags
    tags_verify(
      tags: {
        'tag1' => true,
        'tag 2' => true,
        'tag2' => false,
        'tag3' => true,
        'tag4' => true,
        'tag5' => true,
      }
    )
  end

  def test_b_tags
    tag_prefix = "tag#{rand(999_999_999)}"

    @browser = browser_instance
    login(
      username: 'master@example.com',
      password: 'test',
      url: browser_url,
    )
    tasks_close_all()

    click(css: 'a[href="#manage"]')
    click(css: 'a[href="#manage/tags"]')
    switch(
      css:  '#content .js-newTagSetting',
      type: 'off',
    )

    set(
      css: '#content .js-create input[name="name"]',
      value: tag_prefix + ' A',
    )
    click(css: '#content .js-create .js-submit')
    set(
      css: '#content .js-create input[name="name"]',
      value: tag_prefix + ' a',
    )
    click(css: '#content .js-create .js-submit')
    set(
      css: '#content .js-create input[name="name"]',
      value: tag_prefix + ' B',
    )
    click(css: '#content .js-create .js-submit')
    set(
      css: '#content .js-create input[name="name"]',
      value: tag_prefix + ' C',
    )
    click(css: '#content .js-create .js-submit')

    # set tag (by tab)
    ticket1 = ticket_create(
      data: {
        customer: 'nico',
        group: 'Users',
        title: 'some subject 123äöü - tags no new 1',
        body: 'some body 123äöü - tags no new 1',
      },
      do_not_submit: true,
    )
    sleep 1
    set(
      css: '.active .ticket-form-bottom .token-input',
      value: "#{tag_prefix} A",
    )
    sleep 2
    sendkey(value: :tab)
    sleep 1
    set(
      css: '.active .ticket-form-bottom .token-input',
      value: "#{tag_prefix} a",
    )
    sleep 2
    sendkey(value: :tab)
    sleep 1
    set(
      css: '.active .ticket-form-bottom .token-input',
      value: "#{tag_prefix} B",
    )
    sleep 2
    sendkey(value: :tab)
    sleep 1
    set(
      css: '.active .ticket-form-bottom .token-input',
      value: 'NOT EXISTING',
    )
    sleep 2
    sendkey(value: :tab)
    sleep 1

    click(
      css: '.active .newTicket button.js-submit',
    )
    sleep 5
    if @browser.current_url !~ /#{Regexp.quote('#ticket/zoom/')}/
      raise 'Unable to create ticket!'
    end

    # verify tags
    tags_verify(
      tags: {
        "#{tag_prefix} A" => true,
        "#{tag_prefix} a" => true,
        "#{tag_prefix} B" => true,
        'NOT EXISTING' => false,
      }
    )

    # new ticket with tags in zoom
    ticket1 = ticket_create(
      data: {
        customer: 'nico',
        group: 'Users',
        title: 'some subject 123äöü - tags no new 2',
        body: 'some body 223äöü - tags no new 1',
      },
    )

    click(css: '.active .sidebar .js-newTagLabel')
    set(
      css: '.active .sidebar .js-newTagInput',
      value: "#{tag_prefix} A",
    )
    sleep 2
    sendkey(value: :tab)
    click(css: '.active .sidebar .js-newTagLabel')
    set(
      css: '.active .sidebar .js-newTagInput',
      value: "#{tag_prefix} a",
    )
    sleep 2
    sendkey(value: :tab)
    click(css: '.active .sidebar .js-newTagLabel')
    set(
      css: '.active .sidebar .js-newTagInput',
      value: "#{tag_prefix} B",
    )
    sleep 2
    sendkey(value: :tab)
    click(css: '.active .sidebar .js-newTagLabel')
    set(
      css: '.active .sidebar .js-newTagInput',
      value: 'NOT EXISTING',
    )
    sleep 2
    sendkey(value: :tab)

    # verify tags
    tags_verify(
      tags: {
        "#{tag_prefix} A" => true,
        "#{tag_prefix} a" => true,
        "#{tag_prefix} B" => true,
        'NOT EXISTING' => false,
      }
    )
    reload()
    sleep 2

    # verify tags
    tags_verify(
      tags: {
        "#{tag_prefix} A" => true,
        "#{tag_prefix} a" => true,
        "#{tag_prefix} B" => true,
        'NOT EXISTING' => false,
      }
    )

    click(css: 'a[href="#manage"]')
    click(css: 'a[href="#manage/tags"]')
    switch(
      css:  '#content .js-newTagSetting',
      type: 'on',
    )

  end

  def test_c_link

    @browser = browser_instance
    login(
      username: 'agent1@example.com',
      password: 'test',
      url: browser_url,
    )
    tasks_close_all()

    ticket1 = ticket_create(
      data: {
        customer: 'nico',
        group: 'Users',
        title: 'some subject - link#1',
        body: 'some body - link#1',
      },
    )

    ticket2 = ticket_create(
      data: {
        customer: 'nico',
        group: 'Users',
        title: 'some subject - link#2',
        body: 'some body - link#2',
      },
    )

    click(
      css: '.content.active .links .js-add',
    )
    sleep 2

    set(
      css: '.content.active .modal-body [name="ticket_number"]',
      value: ticket1[:number],
    )
    select(
      css: '.content.active .modal-body [name="link_type"]',
      value: 'Normal',
    )
    click(
      css: '.content.active .modal-footer .js-submit',
    )

    watch_for(
      css: '.content.active .ticketLinks',
      value: ticket1[:title],
    )

    reload()

    watch_for(
      css: '.content.active .ticketLinks',
      value: ticket1[:title],
    )
    click(
      css: '.content.active .ticketLinks .js-delete'
    )
    watch_for_disappear(
      css: '.content.active .ticketLinks',
      value: ticket1[:title],
    )

    reload()

    watch_for_disappear(
      css: '.content.active .ticketLinks',
      value: ticket1[:title],
    )

  end

end
