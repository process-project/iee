# Vapor - EurValve portal

TODO

## Dependencies

  * MRI 2.3.x
  * PostgreSQL

## Installation

```
bin/setup
```

## Running

```
bin/rails server
```

## Testing

To execute all tests run:

```
bin/rspec
```

To execute File Storage integration tests:
1. Get an expired and a valid PLGrid/Prometheus user proxy
2. Put paths to these in proper ENV values (see secrets.yml)
3. Run rspec with proxy tag on:

```
bin/rspec --tag proxy
```

Use guard to execute tests connected with modified file:

```
guard
```

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new pull request
6. When feature is ready add "ready for review" label
